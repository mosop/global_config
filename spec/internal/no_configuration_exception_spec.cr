require "../spec_helper"

module GlobalConfigInternalSpecNoConfigurationException
  extend GlobalConfig::Store

  global_config :config

  it name do
    expect_raises(NoConfig) { config }
  end
end
