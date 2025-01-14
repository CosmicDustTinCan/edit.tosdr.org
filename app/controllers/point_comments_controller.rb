class PointCommentsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_point, only: %i[new create]

  invisible_captcha only: [:create], honeypot: :subject

  def new
    @point_comment = PointComment.new
  end

  def create
    @point_comment = PointComment.new(point_comment_params)
    @point_comment.summary = Kramdown::Document.new(CGI.escapeHTML(@point_comment.summary)).to_html
    @point_comment.user_id = current_user.id
    @point_comment.point_id = @point.id

    if @point_comment.save
      report_spam(@point_comment.summary, 'ham') if current_user.admin || current_user.curator
      flash[:notice] = 'Comment added!'
      redirect_to point_path(@point)
    else
      render 'new'
    end
  end

  private

  def set_point
    @point = Point.find(params[:point_id])
  end

  def point_comment_params
    params.require(:point_comment).permit(:summary, :point_id)
  end
end
