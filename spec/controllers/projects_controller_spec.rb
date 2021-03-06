require 'spec_helper'

RSpec.describe ProjectsController do
  render_views

  let(:project) { FactoryGirl.create(:project) }

  describe 'GET index' do
    before { Timecop.travel Date.parse('2015-12-15') }

    let!(:proposed) { create :project, season: Season.succ, name: 'proposed project' }
    let!(:accepted) { create :project, :accepted, season: Season.succ, name: 'accepted project' }
    let!(:rejected) { create :project, :rejected, season: Season.succ, name: 'rejected project' }

    it 'hides rejected projects' do
      get :index
      expect(response).to be_success
      expect(response.body).to include 'proposed project'
      expect(response.body).to include 'accepted project'
      expect(response.body).not_to include 'rejected project'
    end
  end

  describe 'GET new' do
    it 'requires a login' do
      get :new
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to be_present
    end

    context 'with user logged in' do
      include_context 'with user logged in'

      context 'during project submission time' do
        before do
          allow(Season).to receive(:projects_proposable?) { true }
        end

        it 'returns success' do
          get :new
          expect(response).to be_success
        end

        it "assigns a new project as @project" do
          get :new
          expect(assigns(:project)).to be_a_new(Project)
        end
      end
    end
  end

  describe 'GET show' do
    it 'returns the project page' do
      get :show, id: project.to_param
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    let!(:project) { create(:project, submitter: current_user) }
    context 'with user logged in' do
      include_context 'with user logged in'
      let(:current_user) { create(:user) }

      it 'creates a project and redirects to list' do
        patch :update, id: project.to_param, project: { name: "This is an updated name!" }
        expect(flash[:notice]).not_to be_nil
        expect(response).to redirect_to(projects_path)
      end
    end
  end

  describe 'POST create' do
    context 'with user logged in' do
      include_context 'with user logged in'
      let(:valid_attributes) { attributes_for :project }

      def mailer_jobs
        enqueued_jobs.select do |job|
          job[:job] == ActionMailer::DeliveryJob &&
            job[:args][0] == 'ProjectMailer' && job[:args][1] == 'proposal'
        end
      end

      context 'during project submission time' do
        before do
          allow(Season).to receive(:projects_proposable?) { true }
        end

        it 'creates a project and redirects to thank you message' do
          expect { post :create, project: valid_attributes }.to \
            change { Project.count }.by 1
          expect(response).to redirect_to(receipt_project_path(assigns(:project)))
        end

        it 'sends an email to organizers' do
          expect { post :create, project: valid_attributes }.to \
            change { mailer_jobs.size }.by 1
        end

        it 'fails to create a project from invalid parameters' do
          expect { post :create, project: { name: '' } }.not_to \
            change { Project.count }
          expect(response.body).to include 'prohibited this project from being saved'
          expect(response).to render_template 'new'
        end

        context 'with season' do
          subject { Project.last }

          context 'in December' do
            before do
              Timecop.travel Date.parse('2015-12-06')
              post :create, project: valid_attributes
            end

            it { expect(subject.season.year).to eql '2016' }
          end

          context 'in January' do
            before do
              Timecop.travel Date.parse('2016-01-10')
              post :create, project: valid_attributes
            end

            it { expect(subject.season.year).to eql '2016' }
          end
        end
      end

      context 'after project proposals have been closed' do
        before { Timecop.travel Date.parse('2016-03-01') }

        it 'will not create a project' do
          expect { post :create, project: valid_attributes }.not_to \
            change { Project.count }
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

  end

  describe 'DELETE destroy' do
    context 'with user logged in' do
      include_context 'with user logged in'
      let(:current_user) { create :user }
      let!(:project) { create(:project, submitter: current_user) }

      it 'deletes the project' do
        expect { delete :destroy, id: project.to_param }.to \
          change { Project.count }.by(-1)
        expect(flash[:notice]).not_to be_nil
        expect(response).to redirect_to(projects_path)
      end
    end
  end

end
