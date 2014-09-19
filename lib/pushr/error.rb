module Pushr

  # Module containing Pushr::Error classes, all of which extend StandardError.
  module Error

    # Raised if the entered authentication details (API key or username and password) are incorrect. (Error code: 2)
    class RecordInvalid < StandardError
    end
  end
end
