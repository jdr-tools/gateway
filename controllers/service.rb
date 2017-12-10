module Controllers

  # This controller is instanciated for each service of the suite.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Service < Sinatra::Base

    # @!attribute [rw] service
    #   @return [Arkaan::Monitoring::Service] the service associated to this controller
    attr_reader :service
    # @!attribute [rw] instance
    #   @return [Arkaan::Monitoring::Instance] the deployed instance of the service used to make requests.
    attr_reader :instance
    # @!attribute [rw] connection
    #   @return [Faraday] the faraday connection to make requests on the instance of the service.
    attr_reader :connection

    # Builds the controller with the given service.
    # @param [Arkaan::Monitoring::Service] the service to bind to the controller
    def initialize(service)
      super
      @service = service
      @instance = service.instances.sample
      @connection = Faraday.new(url: instance.url) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
    end

    post '/' do
      @body = JSON.parse(request.body.read.to_s) rescue {}
      @body['token'] = Utils::Seeder.instance.create_gateway.token
      @forwarded = forward_post(service.path, @body.to_json)
      halt @forwarded.status, @forwarded.body
    end

    get '/:id' do
      params['token'] = Utils::Seeder.instance.create_gateway.token
      @forwarded = forward_get("#{service.path}/#{params['id']}")
      halt @forwarded.status, @forwarded.body
    end

    def forward_post(url, body)
      return connection.post do |forwarded_req|
        forwarded_req.url url, params
        forwarded_req.body = body
        forwarded_req.headers['Content-Type'] = 'application/json'
        forwarded_req.options.timeout = 5
        forwarded_req.options.open_timeout = 2
      end
    end

    def forward_get(url)
      return connection.get do |forwarded_req|
        forwarded_req.url url, params
        forwarded_req.headers['Content-Type'] = 'application/json'
        forwarded_req.options.timeout = 5
        forwarded_req.options.open_timeout = 2
      end
    end
  end
end