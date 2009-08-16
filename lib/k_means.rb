$: << File.dirname(__FILE__)
require 'centroid'
require 'node'
require 'ext/enumerable'
require 'ext/object'

class KMeans
  
  attr_reader :centroids, :nodes
  
  def initialize(data, options={})
    k = options[:centroids] || 4
    @verbose = options[:verbose] == true ? true : nil
        
    @nodes = Node.create_nodes(data)
    @centroids = Centroid.create_centroids(k, @nodes)
    
    perform_cluster_process
  end
  
  def inspect
    centroid_pockets = Array.new(@centroids.size) {[]}
    @centroids.each_with_index do |centroid, centroid_index|
      @nodes.each_with_index do |node, node_index|
        if node.closest_centroid == centroid
          centroid_pockets[centroid_index] << node_index
        end
      end
    end
    centroid_pockets.inspect
  end
  
  private
  
  def perform_cluster_process
    iterations = 0
    updates = 1
    while updates > 0 && iterations < 100 
      iterations += 1
      verbose_message("Iteration #{iterations}")
      updates = 0  
      updates += update_nodes
      reposition_centroids
    end
#    puts @centroids.inspect
#    puts @nodes.inspect
  end
  
  def update_nodes
    @nodes.inject(0) do |sum, node|
      sum += node.update_closest_centroid(@centroids)
    end
  end
  
  def reposition_centroids
    @centroids.each do |centroid|
      nodes = [] 
      @nodes.each {|n| nodes << n if n.closest_centroid == centroid}
      centroid.reposition(nodes)
    end
  end
        
  def verbose_message(message)
    puts message if @verbose
  end
      
end