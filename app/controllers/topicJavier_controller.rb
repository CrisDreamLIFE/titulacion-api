class TopicJavierController < ApplicationController
    require 'TopicJavierUtilities'
    def allTopics
      obj = TopicJavierUtilities.new()
      topics = obj.selectAllTopics
      render :json => topics 
    end
  
    
  
  end