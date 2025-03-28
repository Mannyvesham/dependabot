# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `docker_registry2` gem.
# Please instead update this file by running `bin/tapioca gem docker_registry2`.

# source://docker_registry2//lib/registry/version.rb#3
module DockerRegistry2
  class << self
    # source://docker_registry2//lib/docker_registry2.rb#10
    def connect(uri = T.unsafe(nil), opts = T.unsafe(nil)); end

    # source://docker_registry2//lib/docker_registry2.rb#22
    def manifest(repository, tag); end

    # source://docker_registry2//lib/docker_registry2.rb#26
    def manifest_digest(repository, tag); end

    # source://docker_registry2//lib/docker_registry2.rb#14
    def search(query = T.unsafe(nil)); end

    # source://docker_registry2//lib/docker_registry2.rb#18
    def tags(repository); end
  end
end

# source://docker_registry2//lib/registry/blob.rb#4
class DockerRegistry2::Blob
  # @return [Blob] a new instance of Blob
  #
  # source://docker_registry2//lib/registry/blob.rb#7
  def initialize(headers, body); end

  # Returns the value of attribute body.
  #
  # source://docker_registry2//lib/registry/blob.rb#5
  def body; end

  # Returns the value of attribute headers.
  #
  # source://docker_registry2//lib/registry/blob.rb#5
  def headers; end
end

# source://docker_registry2//lib/registry/exceptions.rb#4
class DockerRegistry2::Exception < ::RuntimeError; end

# source://docker_registry2//lib/registry/exceptions.rb#31
class DockerRegistry2::InvalidMethod < ::DockerRegistry2::Exception; end

# Manifest class represents a manfiest or index in an OCI registry
#
# source://docker_registry2//lib/registry/manifest.rb#5
class DockerRegistry2::Manifest < ::Hash
  # Returns the value of attribute body.
  #
  # source://docker_registry2//lib/registry/manifest.rb#6
  def body; end

  # Sets the attribute body
  #
  # @param value the value to set the attribute body to.
  #
  # source://docker_registry2//lib/registry/manifest.rb#6
  def body=(_arg0); end

  # Returns the value of attribute headers.
  #
  # source://docker_registry2//lib/registry/manifest.rb#6
  def headers; end

  # Sets the attribute headers
  #
  # @param value the value to set the attribute headers to.
  #
  # source://docker_registry2//lib/registry/manifest.rb#6
  def headers=(_arg0); end
end

# source://docker_registry2//lib/registry/exceptions.rb#28
class DockerRegistry2::NotFound < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#22
class DockerRegistry2::ReauthenticatedException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/registry.rb#8
class DockerRegistry2::Registry
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @param base_uri [#to_s] Docker registry base URI
  # @param options [Hash] Client options
  # @return [Registry] a new instance of Registry
  #
  # source://docker_registry2//lib/registry/registry.rb#18
  def initialize(uri, options = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#205
  def _pull_v1(repo, manifest, dir); end

  # source://docker_registry2//lib/registry/registry.rb#187
  def _pull_v2(repo, manifest, dir); end

  # source://docker_registry2//lib/registry/registry.rb#119
  def blob(repo, digest, outpath = T.unsafe(nil)); end

  # gets the size of a particular blob, given the repo and the content-addressable hash
  # usually unneeded, since manifest includes it
  #
  # source://docker_registry2//lib/registry/registry.rb#238
  def blob_size(repo, blobSum); end

  # source://docker_registry2//lib/registry/registry.rb#234
  def copy(repo, tag, newregistry, newrepo, newtag); end

  # source://docker_registry2//lib/registry/registry.rb#141
  def digest(image, tag, architecture = T.unsafe(nil), os = T.unsafe(nil), variant = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#38
  def dodelete(url); end

  # source://docker_registry2//lib/registry/registry.rb#30
  def doget(url); end

  # source://docker_registry2//lib/registry/registry.rb#42
  def dohead(url); end

  # source://docker_registry2//lib/registry/registry.rb#34
  def doput(url, payload = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#260
  def last(header); end

  # source://docker_registry2//lib/registry/registry.rb#109
  def manifest(repo, tag); end

  # source://docker_registry2//lib/registry/registry.rb#133
  def manifest_digest(repo, tag); end

  # source://docker_registry2//lib/registry/registry.rb#269
  def manifest_sum(manifest); end

  # When a result set is too large, the Docker registry returns only the first items and adds a Link header in the
  # response with the URL of the next page. See <https://docs.docker.com/registry/spec/api/#pagination>. This method
  # iterates over the pages and calls the given block with each response.
  #
  # source://docker_registry2//lib/registry/registry.rb#49
  def paginate_doget(url); end

  # Parse the value of the Link HTTP header and return a Hash whose keys are the rel values turned into symbols, and
  # the values are URLs. For example, `{ next: '/v2/_catalog?n=100&last=x' }`.
  #
  # source://docker_registry2//lib/registry/registry.rb#245
  def parse_link_header(header); end

  # source://docker_registry2//lib/registry/registry.rb#173
  def pull(repo, tag, dir); end

  # source://docker_registry2//lib/registry/registry.rb#224
  def push(manifest, dir); end

  # source://docker_registry2//lib/registry/registry.rb#166
  def rmtag(image, tag); end

  # source://docker_registry2//lib/registry/registry.rb#63
  def search(query = T.unsafe(nil)); end

  # @raise [DockerRegistry2::RegistryVersionException]
  #
  # source://docker_registry2//lib/registry/registry.rb#226
  def tag(repo, tag, newrepo, newtag); end

  # source://docker_registry2//lib/registry/registry.rb#73
  def tags(repo, count = T.unsafe(nil), last = T.unsafe(nil), withHashes = T.unsafe(nil), auto_paginate: T.unsafe(nil)); end

  private

  # source://docker_registry2//lib/registry/registry.rb#380
  def authenticate_bearer(header); end

  # source://docker_registry2//lib/registry/registry.rb#316
  def do_basic_req(type, url, stream = T.unsafe(nil), payload = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#348
  def do_bearer_req(type, url, header, stream = T.unsafe(nil), payload = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#279
  def doreq(type, url, stream = T.unsafe(nil), payload = T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#419
  def headers(payload: T.unsafe(nil), bearer_token: T.unsafe(nil)); end

  # source://docker_registry2//lib/registry/registry.rb#405
  def split_auth_header(header = T.unsafe(nil)); end
end

# source://docker_registry2//lib/registry/exceptions.rb#7
class DockerRegistry2::RegistryAuthenticationException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#10
class DockerRegistry2::RegistryAuthorizationException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#16
class DockerRegistry2::RegistrySSLException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#13
class DockerRegistry2::RegistryUnknownException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#19
class DockerRegistry2::RegistryVersionException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/exceptions.rb#25
class DockerRegistry2::UnknownRegistryException < ::DockerRegistry2::Exception; end

# source://docker_registry2//lib/registry/version.rb#4
DockerRegistry2::VERSION = T.let(T.unsafe(nil), String)
