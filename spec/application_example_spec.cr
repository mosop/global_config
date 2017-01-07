require "./spec_helper"

module GlobalConfigSpecApplicationExample
  ENV["AWS_ACCESS_KEY_ID"] = "CEAKDQDSOYQYEWMAGAGO"
  ENV["AWS_SECRET_ACCESS_KEY"] = "nON5qHbvaE70moLJ..."
  ENV["MY_APP_DEFUALT_REGION"] = "ap-northeast-1"
  ENV["AWS_DEFUALT_REGION"] = "us-east-1"

  module MeetsAws
    extend GlobalConfig::Store

    global_config :access_key_id, env: {
      :MY_APP_AWS_ACCESS_KEY_ID,
      :AWS_ACCESS_KEY_ID
    }

    global_config :secret_access_key, env: {
      :MY_APP_AWS_SECRET_ACCESS_KEY,
      :AWS_SECRET_ACCESS_KEY
    }

    global_config :region, env: {
      :MY_APP_DEFUALT_REGION,
      :AWS_DEFAULT_REGION
    }
  end

  MeetsAws.global_config_context :sign_in,
    :access_key_id,
    :secret_access_key,
    :region

  it name do
    MeetsAws.access_key_id.should eq "CEAKDQDSOYQYEWMAGAGO"
    MeetsAws.secret_access_key.should eq "nON5qHbvaE70moLJ..."
    MeetsAws.region.should eq "ap-northeast-1"

    MeetsAws.access_key_id = "STWUSDFLRNNBBSCCSQXC"
    MeetsAws.secret_access_key = "6YzNGvZ34IrVeE62..."
    MeetsAws.region = "eu-central-1"

    MeetsAws.access_key_id.should eq "STWUSDFLRNNBBSCCSQXC"
    MeetsAws.secret_access_key.should eq "6YzNGvZ34IrVeE62..."
    MeetsAws.region.should eq "eu-central-1"

    MeetsAws.sign_in(access_key_id: "QEQDEOJYFEUJIJUHVOQD", secret_access_key: "RRAUvo9m8I9TYyjT...", region: "ap-southeast-1") do
      MeetsAws.access_key_id.should eq "QEQDEOJYFEUJIJUHVOQD"
      MeetsAws.secret_access_key.should eq "RRAUvo9m8I9TYyjT..."
      MeetsAws.region.should eq "ap-southeast-1"
      MeetsAws.sign_in(access_key_id: "ZRAGPSWMQBVWKBDQIQLL", secret_access_key: "H6ZkdYzkndHmTI4W...", region: "eu-west-1") do
        MeetsAws.access_key_id.should eq "ZRAGPSWMQBVWKBDQIQLL"
        MeetsAws.secret_access_key.should eq "H6ZkdYzkndHmTI4W..."
        MeetsAws.region.should eq "eu-west-1"
      end
      MeetsAws.access_key_id.should eq "QEQDEOJYFEUJIJUHVOQD"
      MeetsAws.secret_access_key.should eq "RRAUvo9m8I9TYyjT..."
      MeetsAws.region.should eq "ap-southeast-1"
    end

    MeetsAws.region("us-west-1") do
      MeetsAws.region.should eq "us-west-1"
    end

    MeetsAws.region.should eq "eu-central-1"
  end
end
