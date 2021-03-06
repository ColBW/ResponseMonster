class SurveysController < ApplicationController
  require 'debugger'
  before_filter :authenticate
  before_filter(except: [:summary, :login, :check]) { |controller| controller.check_permissions(Course.find(params[:course_id])) }
  before_filter :admin_user, only: [:index]

  def show
    @survey = Survey.find(params[:id])
    @course = @survey.course
    @times_submitted = @survey.assessments.where(user_id: current_user.id).length
    @responses = []
    @survey.polls.each do |poll|
      poll.answers.each do |answer|
        @responses << Response.new
      end
    end
  end

  def new
    @survey = Survey.new
    @course = Course.find(params[:course_id])
  end

  def edit
    @survey = Survey.find(params[:id])
    @course = Course.find(params[:course_id])
  end

  def create
    @course = Course.find(params[:course_id])
    @survey = @course.surveys.new(params[:survey])

    total = 0
    @survey.polls.each do |poll|
      total += poll.points
    end
    @survey.total_points = total

    if @survey.save
      redirect_to course_path(@course), notice: "Survey was successfully created"
    else
      render new_course_survey_path(@course), notice: "There were some errors"
    end
  end

  def update
    @survey = Survey.find(params[:id])
    @course = @survey.course

    if @survey.update_attributes(params[:survey])
      redirect_to course_path(@course), notice: 'Survey was successfully updated'
    else
      render "edit", notice: "There were some errors"
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    @course = @survey.course

    if @survey.destroy
      redirect_to course_path(@course), notice: "Survey successfully deleted"
    else
      redirect_to course_path(@course), notice: "Survey was not deleted"
    end
  end

  def activate
    @survey = Survey.find(params[:id])
    @course = @survey.course
    if @survey.toggle_survey(@survey)
      redirect_to course_path(@course), notice: "Activated survey"
    else
      redirect_to course_path(@course), notice: "Could not activate survey"
    end
  end

  def deactivate
    @survey = Survey.find(params[:id])
    @course = @survey.course
    if @survey.toggle_survey(@survey)
      redirect_to course_path(@course), notice: "Deactivated survey"
    else
      redirect_to course_path(@course), notice: "Could not deactivate survey"
    end
  end

  def login
    @survey = Survey.find(params[:id])
    @course = @survey.course
    if @course.teacher_id == current_user.id || is_admin? || @survey.password.nil? || @survey.password.empty?
      redirect_to new_course_survey_assessment_path(@course, @survey)
    end
  end

  def stats
    @survey = Survey.find(params[:id])
    @course = @survey.course
    @assessments = @survey.assessments

    # get all the scores
    graph_data = @assessments.collect{|a| a.score}
    # isolate unique scores
    graph_cats = []
    graph_data.each{|g| graph_cats << g unless g.in? graph_cats}
    # sort isolated scores to make grapher happy
    graph_cats = graph_cats.sort
    # count individual scores
    graph_map = graph_cats.collect{|g| graph_data.select{|y| y==g}.length}
    graph_cats = graph_cats.each{|g| String(g)}

    @gd_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "column"
      f.options[:title][:text] = "Grade Distribution"
      f.series(showInLegend: false, data: graph_map)
      f.options[:xAxis][:categories] = graph_cats
      f.options[:xAxis][:title] = { text: "Grades" }
      f.options[:yAxis][:allowDecimals] = false
      f.options[:yAxis][:title] = { text: "Amount" }
    end
    @answer_charts = []
    @survey.polls.each do |p|
      # Get answer data for each
      answer_data = p.answers.collect{|a| [a.answer_text, Response.where(choiceId: a.id).length]}
      a_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.options[:chart][:type] = "pie"
        f.options[:title][:text] = "<b>" + p.question_text + "</b>"
        f.options[:plotOptions][:pie] = { allowPointSelect: true }
        f.series(type: "pie", name: "Count", data: answer_data)
      end
      @answer_charts << a_chart
    end

  end

  def check
    @survey = Survey.find(params[:id])
    @course = @survey.course
    if params["pass"][:password] && params["pass"][:password] == @survey.password
      redirect_to new_course_survey_assessment_path(@course, @survey)
    else
      flash.now[:error] = "The password you entered was incorrect"
      render "login"
    end
  end

end

####################
# Depreciated methods
####################
#  def summary
#    @survey = Survey.find(params[:id])
#    @course = @survey.course
#    @polls = @survey.polls.all
#    if !params[:assessment_id].nil?
#      @student_assessment = Assessment.find(params[:assessment_id])
#    else
#      @student_assessment = Assessment.where(user_id: current_user.id, survey_id: @survey.id).first
#    end
#    @grades = []
#    if !params[:assessment_id].nil? && current_user.id == @course.teacher_id
#      @assessment = Assessment.find(params[:assessment_id])
#    end
#    @responses = current_user.responses.all
#  end


#  def grade
#    @survey = Survey.find(params[:id])
#    @course = @survey.course
#    @assessments = @survey.assessments
#  end
#
#  def newgrade
#    assessment = Assessment.find(params[:assessment_id])
#    @survey = assessment.survey
#    changing = []
#    params.keys[2..-7].each do |key|
#      response = Response.find(key.split("s")[1])
#      response.points = params[key]
#      response.save
#    end
#    assessment.score = 0
#    assessment.responses.each do |response|
#      assessment.score += response.points
#    end
#    assessment.is_graded = true
#    assessment.save
#    redirect_to grade_course_survey_path(@survey.course, @survey), notice: "Successfully graded #{assessment.user.first_name}'s quiz"
#  end
