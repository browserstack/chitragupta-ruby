module Chitragupta
    module Constants
      LOG_LEVEL_INFO = "info"
      CATEGORY_SERVER = "server"
      CATEGORY_PROCESS = "process"
      CATEGORY_WORKER = "worker"

      FIELD_LENGTH_LIMITS = {
        :dynamic_data => 5000,
        :headers => 1000,
        :params => 10000
      }
    end
  end
  