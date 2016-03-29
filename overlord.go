package main

import (
	"log"
	"time"

	"github.com/metral/overlord/lib"
)

func main() {
	fleetResult := lib.Result{}
	var f *lib.Result = &fleetResult

	lib.SetMachinesSeen([]string{})

	// Get Fleet machines
	var masterFleetMachine lib.FleetMachine
	var createdFiles, allMachinesSeen []string
	for {
		lib.GetFleetMachines(f)

		totalSeen := len(allMachinesSeen)
		log.Printf("------------------------------------------------------------")
		log.Printf("Current # of machines seen/deployed to: (%d)\n", totalSeen)

		totalMachines := len(f.Node.Nodes)
		log.Printf("------------------------------------------------------------")
		log.Printf("Current # of machines discovered: (%d)\n", totalMachines)

		var fleetMachine lib.FleetMachine
		// Get Fleet machines metadata
		for _, resultNode := range f.Node.Nodes {
			lib.WaitForMetadata(&resultNode, &fleetMachine)

			switch fleetMachine.Metadata["kubernetes_role"] {
			case "master":
				masterFleetMachine = fleetMachine
			}

			if !lib.MachineSeen(allMachinesSeen, fleetMachine.ID) &&
				masterFleetMachine.ID != "" {

				log.Printf("------------------------------------------------------------")
				log.Printf("Found machine:\n")
				fleetMachine.PrintString()

				if lib.IsMaster(&fleetMachine) || lib.IsMinion(&fleetMachine) {
					allMachinesSeen = append(allMachinesSeen, fleetMachine.ID)

					if lib.IsMaster(&fleetMachine) {
						createdFiles = lib.CreateMasterUnits(&fleetMachine)
					} else if lib.IsMinion(&fleetMachine) {
						createdFiles = lib.CreateMinionUnits(
							&masterFleetMachine, &fleetMachine)
					}
					for _, file := range createdFiles {
						if !lib.UnitFileCompleted(file) {
							lib.StartUnitFile(file)
							lib.WaitUnitFileComplete(file)
						}
					}

					lib.SetMachinesSeen(allMachinesSeen)
				}
			}
		}

		time.Sleep(1 * time.Second)
		allMachinesSeen = lib.GetMachinesSeen()
	}
}
