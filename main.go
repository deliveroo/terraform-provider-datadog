package main

import (
	"github.com/deliveroo/terraform-provider-datadog/datadog"
	"github.com/hashicorp/terraform/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: datadog.Provider})
}
