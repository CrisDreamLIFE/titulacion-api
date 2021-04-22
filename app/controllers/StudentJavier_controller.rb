class StudentJavierController < ApplicationController
  require 'StudentJavierUtilities'

  def index
  end

  def allStudents
    data=[]
    obj = StudentJavierUtilities.new()
    students = obj.selectAllStudent
    render json: students
  end

  def test
    obj = StudentJavierUtilities.new()
    students = obj.testRequest
    render json: students
  end
  
end