# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Virgin
          include TimezoneDefinition
          
          linked_timezone 'America/Virgin', 'America/Port_of_Spain'
        end
      end
    end
  end
end
