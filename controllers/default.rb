module Controllers
  # This controller is just used to intercept all requests if they are not belonging to a service, and display a unified message.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Default < Sinatra::Base

    get '/gateway' do
      gateways = Arkaan::Monitoring::Gateway.where(
        :enum_type.ne => :local,
        running: true,
        active: true
      )
      halt 200, gateways.map(&:url).to_json
    end

    get '/*' do
      halt 404, {message: 'path_not_found'}.to_json
    end
    post '/*' do
      halt 404, {message: 'path_not_found'}.to_json
    end
    put '/*' do
      halt 404, {message: 'path_not_found'}.to_json
    end
    delete '/*' do
      halt 404, {message: 'path_not_found'}.to_json
    end
    # This route is to avoid the "downstream app not set" error.
    get '/favicon.ico' do; end
  end
end