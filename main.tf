provider "datadog" {
  api_key = "${var.datadog_api_key}"
  app_key = "${var.datadog_app_key}"
}

locals {
  account_ids = {
    production = "818921491005"
    staging = "517902663915"
  }

  alb_tags = "aws_account:${lookup(local.account_ids, var.env)},applicationname:${var.hopper_app_name}"
  newrelic_tags = "application:${var.newrelic_app_name}"
}

resource "datadog_timeboard" "app_board" {
  title       = "${title(replace(var.hopper_app_name, "-", " "))} - ${title(var.env)} - App Metrics"

  description = "Basic service metrics, created by Terraform"
  read_only   = true

  graph {
    title = "95th percentile latency on ALB"
    viz   = "query_value"
    custom_unit  = "ms"

    request {
      q    = "avg:aws.applicationelb.target_response_time.p95{${local.alb_tags}}*1000"
      type = "line"

      conditional_format {
        palette = "white_on_green"
        comparator = "<"
        value = "500"
      }

      conditional_format {
        palette = "white_on_yellow"
        comparator = ">"
        value = "1000"
      }

      conditional_format {
        palette = "white_on_red"
        comparator = ">"
        value = "1500"
      }
    }
  }

  graph {
    title = "Requests count (now, day ago, week ago) on ALB"
    viz   = "timeseries"
    custom_unit  = "reqs"

    request {
      q    = "sum:aws.applicationelb.request_count{${local.alb_tags}}.as_count()"
      type = "line"
      style {
        palette = "classic"
        type = "solid"
      }
    }

    request {
      q    = "day_before(sum:aws.applicationelb.request_count{${local.alb_tags}}.as_count())"
      type = "line"
      style {
        palette = "purple"
        type = "solid"
      }
    }

    request {
      q    = "week_before(sum:aws.applicationelb.request_count{${local.alb_tags}}.as_count())"
      type = "line"
      style {
        palette = "orange"
        type = "solid"
      }
    }
  }

  graph {
    title = "Status codes on ALB"
    viz   = "timeseries"

    request {
      q    = "sum:aws.applicationelb.httpcode_target_2xx{${local.alb_tags}}.as_count()"
      type = "bars"
      stacked = true

      style {
        palette = "cool"
        width = "solid"
      }
    }

    request {
      q    = "sum:aws.applicationelb.httpcode_target_3xx{${local.alb_tags}}.as_count()"
      type = "bars"
      stacked = true

      style {
        palette = "classic"
        width = "solid"
      }
    }

    request {
      q    = "sum:aws.applicationelb.httpcode_target_4xx{${local.alb_tags}}.as_count()"
      type = "bars"
      stacked = true

      style {
        palette = "orange"
        width = "solid"
      }
    }

    request {
      q    = "sum:aws.applicationelb.httpcode_target_5xx{${local.alb_tags}}.as_count()"
      type = "bars"
      stacked = true

      style {
        palette = "warm"
        width = "solid"
      }
    }
  }


  graph {
    title = "Requests count (now, day ago, week ago) on Newrelic"
    viz   = "timeseries"
    custom_unit  = "reqs/minute"

    request {
      q    = "sum:new_relic.application_summary.throughput{${local.newrelic_tags}}"
      type = "line"
      style {
        palette = "classic"
        type = "solid"
      }
    }

    request {
      q    = "day_before(sum:new_relic.application_summary.throughput{${local.newrelic_tags}})"
      type = "line"
      style {
        palette = "purple"
        type = "solid"
      }
    }

    request {
      q    = "week_before(sum:new_relic.application_summary.throughput{${local.newrelic_tags}})"
      type = "line"
      style {
        palette = "orange"
        type = "solid"
      }
    }
  }

  graph {
    title = "Error rates (now, week ago) on Newrelic"
    viz   = "timeseries"
    custom_unit  = "%"

    request {
      q    = "avg:new_relic.application_summary.error_rate{${local.newrelic_tags}}"
      type = "line"
      style {
        palette = "classic"
        type = "solid"
      }
    }

    request {
      q    = "week_before(avg:new_relic.application_summary.error_rate{${local.newrelic_tags}})"
      type = "line"
      style {
        palette = "orange"
        type = "solid"
      }
    }
  }

  graph {
    title = "CPU Utilisation"
    viz   = "timeseries"
    services = ["changelog-dashboard-web", "changelog-dashboard-worker"]

    request {
      q    = "avg:aws.ecs.cpuutilization.maximum{clustername:production,servicename:%service%}"
      type = "line"
      style {
        palette = "classic"
        type = "solid"
      }
    }
  }
}

