package cmd

import (
	"flag"
	"fmt"

	"github.com/gnolang/gno/tm2/pkg/commands"
)

const Test5_GroupName = "test5"
const Test5_MonitorPrefixName = "Test 5"
const Test5_MonitorFqdn = "test5.gno.land"

type ApiCallerCfg struct {
	AuthToken         string
	MonitorGroupName  string
	MonitorPrefixName string
	MonitorFqdn       string
	AdditionalPath    string
}

func NewApiCallerCmd(apiCallerCfg *ApiCallerCfg, executor commands.ExecMethod) *commands.Command {
	return commands.NewCommand(
		commands.Metadata{
			Name:       "betterapi",
			ShortUsage: "betterapi [flags]",
			ShortHelp:  "run better stack api caller",
			LongHelp:   "Step by step caller of Betterstack Api to generate Monitors and Status Page entries in Betterstack website",
		},
		apiCallerCfg,
		executor)
}

func (c *ApiCallerCfg) RegisterFlags(fs *flag.FlagSet) {
	// auth token
	fs.StringVar(
		&c.AuthToken,
		"token",
		"",
		fmt.Sprintf("[REQUIRED] auth token for calling Betterstack APIs"),
	)

	// group name
	fs.StringVar(
		&c.MonitorGroupName,
		"group",
		c.MonitorGroupName,
		fmt.Sprintf("name of group of monitors to be created"),
	)

	// prefix name
	fs.StringVar(
		&c.MonitorPrefixName,
		"prefix",
		c.MonitorPrefixName,
		fmt.Sprintf("prefix name applied to monitors"),
	)

	// fqdn
	fs.StringVar(
		&c.MonitorFqdn,
		"fqdn",
		c.MonitorFqdn,
		fmt.Sprintf("fully qualied domain name to be applied to default monitors"),
	)

	// additional path
	fs.StringVar(
		&c.AdditionalPath,
		"extra-path",
		"",
		fmt.Sprintf("path for importing addinial services"),
	)
}
