# frozen_string_literal: true

# app/controllers/document_comments_controller.rb
class DocumentCommentsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_document, only: %i[new create]

  invisible_captcha only: [:create], honeypot: :subject

  def new
    @document_comment = DocumentComment.new
  end

  def create
    @document_comment = DocumentComment.new(document_comment_params)
    @document_comment.summary = Kramdown::Document.new(CGI.escapeHTML(@document_comment.summary)).to_html
    @document_comment.user_id = current_user.id
    @document_comment.document_id = @document.id

    if @document_comment.save
      report_spam(@document_comment.summary, 'ham') if current_user.admin || current_user.curator
      flash[:notice] = 'Comment added!'
      redirect_to document_path(@document)
    else
      render 'new'
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def document_comment_params
    params.require(:document_comment).permit(:summary, :document_id)
  end
end
