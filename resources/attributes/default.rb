default["druid"]                                = {}
default["druid"]["services"]                    = {}
default["druid"]["services"]["broker"]          = false
default["druid"]["services"]["coordinator"]     = false
default["druid"]["services"]["historical"]      = false
default["druid"]["services"]["middlemanager"]   = false
default["druid"]["services"]["overlord"]        = false

#Flags
node["druid-broker"]["registered"] = false
node["druid-coordinator"]["registered"] = false
node["druid-historical"]["registered"] = false
node["druid-middlemanager"]["registered"] = false
node["druid-overlord"]["registered"] = false
