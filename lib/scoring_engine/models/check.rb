module ScoringEngine
  module Models
    class Check < ActiveRecord::Base
      attr_accessible :team_id, :server_id, :service_id, :passed, :request, :response, :round

      belongs_to :team
      belongs_to :server
      belongs_to :service

      validates :request, presence: true
      validates :response, presence: true
      validates :team, presence: { message: "must exist" }
      validates :server, presence: { message: "must exist" }
      validates :service, presence: { message: "must exist" }
      validates :round, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      validate :right_team?


      def self.minimal; select('team_id,server_id,service_id,id,passed,round,created_at') end
      def self.passing; where("passed = ?", true) end
      def self.failing; where("passed = ?", false) end
      def self.ordered; order('team_id ASC, server_id ASC, service_id ASC, round DESC, id DESC') end
      def self.latest; order('round DESC').first end
      def self.last_round; self.latest ? self.latest.round : 0 end
      def self.next_round; self.last_round == 0 ? 0 : self.last_round + 1 end
      def self.bargraph; [self.points] end

      def right_team?
        team = Team.find_by_id(team_id)
        server = Server.find_by_id(server_id)
        service = Service.find_by_id(service_id)
        unless team && server && service && team.id == server.team_id && team.id == service.team_id && team.id == team_id
          errors.add_to_base("Server, Service, and Check must belong to same Team")
        end
        unless team && server && service && server.id == service.server_id && server.id == server_id
          errors.add_to_base("Service and Check must belong to same Server")
        end
      end

      # Standard permissions
      def can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
      def self.can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
      def self.can_new?(member,team_id) member.whiteteam? end
      def can_edit?(member,team_id) member.whiteteam? end
      def can_create?(member,team_id) member.whiteteam? end
      def can_update?(member,team_id) member.whiteteam? end
      def can_destroy?(member,team_id) member.whiteteam? end
    end
  end
end