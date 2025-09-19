package xray

import (
    "encoding/json"
    "fmt"
    "github.com/xtls/xray-core/core"
    "github.com/xtls/xray-core/main/commands/base"
)

var server core.Server

// StartXray starts the Xray server with the given config
func StartXray(configJSON string) error {
    config, err := core.LoadConfig("json", []byte(configJSON))
    if err != nil {
        return fmt.Errorf("failed to load config: %v", err)
    }
    
    server, err = core.New(config)
    if err != nil {
        return fmt.Errorf("failed to create server: %v", err)
    }
    
    return server.Start()
}

// StopXray stops the Xray server
func StopXray() error {
    if server != nil {
        return server.Close()
    }
    return nil
}

// GetStats returns connection statistics
func GetStats() string {
    stats := map[string]interface{}{
        "uplink": 0,
        "downlink": 0,
    }
    
    data, _ := json.Marshal(stats)
    return string(data)
}
