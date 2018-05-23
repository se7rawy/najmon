module Fog
  module Volume
    class OpenStack
      class V1
        class Real
          include Fog::Volume::OpenStack::Real
        end
        class Mock
          include Fog::Volume::OpenStack::Mock
        end
      end
    end
  end
end
