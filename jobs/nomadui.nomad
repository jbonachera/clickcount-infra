{
    "Job": {
        "Region": "global",
        "ID": "nomadui",
        "Name": "nomadui",
        "Type": "service",
        "Priority": 50,
        "AllAtOnce": false,
        "Datacenters": [
            "dc1"
        ],
        "Constraints": [
            {
                "LTarget": "${attr.kernel.name}",
                "RTarget": "linux",
                "Operand": "="
            }
        ],
        "TaskGroups": [
            {
                "Name": "nomadui",
                "Count": 2,
                "Constraints": null,
                "Tasks": [
                    {
                        "Name": "front",
                        "Driver": "docker",
                        "User": "",
                        "Config": {
                            "image": "iverberk/nomad-ui:0.1.0",
                            "port_map": [
                                {
                                    "web": 3000
                                }
                            ]
                        },
                        "Constraints": null,
                        "Env":{
                          "NOMAD_ADDR": "172.17.0.1"
                        },
                        "Services": [
                            {
                                "Id": "",
                                "Name": "nomadui-front",
                                "Tags": [
                                    "traefik.enable=true",
                                    "traefik.frontend.entryPoints=http",
                                    "traefik.backend.weight=10",
                                    "traefik.frontend.rule=Host:nomadui.app.cloud.vx-labs.net"
                                ],
                                "PortLabel": "web",
                                "Checks": [
                                    {
                                        "Id": "",
                                        "Name": "alive",
                                        "Type": "http",
                                        "Command": "",
                                        "Args": null,
                                        "Path": "/",
                                        "Protocol": "",
                                        "PortLabel": "web",
                                        "Interval": 10000000000,
                                        "Timeout": 2000000000
                                    }
                                ]
                            }
                        ],
                        "Resources": {
                            "CPU": 500,
                            "MemoryMB": 256,
                            "DiskMB": 300,
                            "IOPS": 0,
                            "Networks": [
                                {
                                    "Public": false,
                                    "CIDR": "",
                                    "ReservedPorts": null,
                                    "DynamicPorts": [
                                        {
                                            "Label": "web",
                                            "Value": 0
                                        }
                                    ],
                                    "IP": "",
                                    "MBits": 10
                                }
                            ]
                        },
                        "Meta": null,
                        "KillTimeout": 5000000000,
                        "LogConfig": {
                            "MaxFiles": 10,
                            "MaxFileSizeMB": 10
                        },
                        "Artifacts": null
                    }
                ],
                "RestartPolicy": {
                    "Interval": 300000000000,
                    "Attempts": 10,
                    "Delay": 25000000000,
                    "Mode": "delay"
                },
                "Meta": null
            }
        ],
        "Update": {
            "Stagger": 10000000000,
            "MaxParallel": 1
        },
        "Periodic": null,
        "Meta": null,
        "Status": "",
        "StatusDescription": "",
        "CreateIndex": 0,
        "ModifyIndex": 0,
        "JobModifyIndex": 0
    }
}

