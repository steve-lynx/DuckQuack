# encoding: utf-8

class Object
  include AppHelpers
end

if RUBY_PLATFORM =~ /java/
  #jdbc-sqlite3 return string for timestamp fields
  class String
    def to_datetime
      begin
        DateTime.parse(self)
      rescue
        self
      end
    end

    def strftime(pattern)
      begin
        DateTime.parse(self).strftime(pattern)
      rescue
        self
      end
    end

    def day
      begin
        DateTime.parse(self).day
      rescue
        self
      end
    end

    def month
      begin
        DateTime.parse(self).month
      rescue
        self
      end
    end

    def year
      begin
        DateTime.parse(self).year
      rescue
        self
      end
    end
  end
end
