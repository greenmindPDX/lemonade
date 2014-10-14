require 'spec_helper'


describe "Zaphod integration test", :type => :integration do
  let(:fixture) { 'fixture/callback' }

  subject(:photo) { Zaphod::PhotoPoster.run }
  #let(:params) { JSON.parse(json_fixture_from_file(format_worker_fixture) ) }
  
  before(:all) do
    WebMock.allow_net_connect!
  end


  # Based on the supplied access_token, it should push to flickr
  #
  context 'submitting valid data' do


    it 'should set_payload' do
      expect(photo.set_payload).to be_a(Hash)

      expect(pantene.do_callback).to eq true
    end

  end


end
