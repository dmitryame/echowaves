ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :recent => "%I:%M%p",
        :pretty => "%b %d, %Y",
        :pretty_long => "%b %d, %Y %I:%M%p",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )