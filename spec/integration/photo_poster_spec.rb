require 'spec_helper'


describe "Zaphod integration test", :type => :integration do
  let(:fixture) { 'fixture/callback' }
  subject(:photo) { Zaphod::PhotoPoster.new(cfg,log) }
  
  let(:cfg){
      {'flickr_access_token'  => ENV['FLICKR_ACCESS_TOKEN'], 
      'flickr_access_secret' => ENV['FLICKR_ACCESS_SECRET'], 
      'flickr_key'           => ENV['FLICKR_KEY'],
      'flickr_shared_secret' => ENV['FLICKR_SHARED_SECRET'],
      'ig_access_token'      => ENV['IG_ACCESS_TOKEN'],
      'ig_client_id'         => ENV['IG_CLIENT_ID']}
  }

  let(:log){''}
  let(:data){ {
        'caption'   => "Interesting, #amiright?",  #['caption']['text']
        'photo_url' => "http://httpcats.herokuapp.com/500",
        'title'     => "Internal Server Error"
    }
  }

  #let(:params) { JSON.parse(json_fixture_from_file(format_worker_fixture) ) }
  
  before(:all) do
    WebMock.allow_net_connect!
  end

  # Based on the supplied access_token, it should push to flickr
  # FIXME load data from fixture
  # currently smells like a unit test
  context 'submitting valid data' do
    
    it 'should set_payload' do
      expect(photo.set_payload(data)).to be_a(Hash)
    end

  end



end
