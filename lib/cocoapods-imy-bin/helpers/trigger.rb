require 'json'

module CBin

    class Trigger

        attr_accessor :podname
        attr_accessor :version
        attr_accessor :commit
        attr_accessor :message
        def initialize(argv)
            data = argv.first
            json = JSON.parse(data)
            # p json
            msg = json['commits'].first['message']
            /【([a-zA-Z0-9]*)-(.*)】/.match(msg)
            @podname = $1
            @version = $2
            @commit = json['after']
            @message = json['commits'][0]['message'].chomp
        end

        def validate_object
            p @podname , @version, @commit
            if @podname.nil? || @commit.nil?
                p "no framework or commit founds"
                return nil
            end
            return @podname,@version,@commit
        end
    end
end
