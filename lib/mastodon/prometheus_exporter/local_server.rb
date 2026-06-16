# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus_exporter/client'

module Mastodon::PrometheusExporter
  module LocalServer
    mattr_accessor :bind, :port

    def self.setup!
      server = PrometheusExporter::Server::WebServer.new(bind:, port:)
      server.start

      # wire up a default local client
      PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)
    rescue Errno::EADDRINUSE
      # Another process on this host already owns the exporter server
      # (e.g. multiple sidekiq services). Fall back to a network client
      # that sends metrics to the existing server.
      Rails.logger.info "PrometheusExporter: port #{port} in use, falling back to remote client"
      PrometheusExporter::Client.default =
        PrometheusExporter::Client.new(host: bind || 'localhost', port: port)
    end
  end
end
