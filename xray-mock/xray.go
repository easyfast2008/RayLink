// Package xray provides a mock implementation for development
package xray

import (
    "encoding/json"
    "fmt"
    "time"
)

// MockServer simulates Xray server for development
type MockServer struct {
    isRunning bool
    startTime time.Time
}

var server = &MockServer{}

// StartXray starts the mock Xray server
func StartXray(configJSON string) string {
    server.isRunning = true
    server.startTime = time.Now()
    return "Mock server started successfully"
}

// StopXray stops the mock Xray server
func StopXray() string {
    server.isRunning = false
    return "Mock server stopped"
}

// GetStats returns mock connection statistics
func GetStats() string {
    stats := map[string]interface{}{
        "uplink": 1024 * 1024 * 10,  // 10 MB
        "downlink": 1024 * 1024 * 50, // 50 MB
        "isRunning": server.isRunning,
    }
    
    data, _ := json.Marshal(stats)
    return string(data)
}

// TestConnection simulates a connection test
func TestConnection(server string) string {
    result := map[string]interface{}{
        "server": server,
        "ping": 45,
        "status": "connected",
    }
    
    data, _ := json.Marshal(result)
    return string(data)
}
