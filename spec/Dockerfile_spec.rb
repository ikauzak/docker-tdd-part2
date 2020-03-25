require 'serverspec'
require 'docker'

# Setting up docker image
describe 'Dockerfile' do
  before(:all) do
    @image = Docker::Image.build_from_dir('.')
    @image.tag(repo: 'ubuntu-teste', tag: 'novo')

    set :os, family: :ubuntu
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, { 'Entrypoint' => ['bash'] }
  end

  # Image infrastructure tests
  it 'should have the maintaner label' do
    expect(@image.json['Config']['Labels'].key?('maintainer'))
  end

  it 'should be linux Os type' do
    expect @image.json['Os'].eql? 'linux'
  end

  it 'should has no user' do
    expect(@image.json['Config']['User'].nil?)
  end

  it 'should has repo tags' do
    expect(@image.json['RepoTags'].include?('ubuntu-teste:novo'))
  end

  it 'should has port 80 exposed' do
    expect(@image.json['ContainerConfig']['ExposedPorts'].key?('80/tcp')).to be
  end

  # Container applications and files tests
  %w[vim nginx httpd].each do |app|
    describe package(app) do
      it { should be_installed }
    end
  end

  describe port(80) do
    it { should be_listening.with('tcp') }
  end

  describe command('vim --help') do
    its(:exit_status) { should eq 0 }
  end

  describe command('cat /usr/share/nginx/html/index.html') do
    its(:stdout) { should_not contain('Welcome to') }
  end
end
