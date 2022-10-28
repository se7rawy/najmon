# frozen_string_literal: true

class Admin::StatusPolicy < ApplicationPolicy
  def initialize(current_account, record, preloaded_relations = {})
    super(current_account, record)

    @preloaded_relations = preloaded_relations
  end

  def index?
    role.can?(:manage_reports, :manage_users)
  end

  def show?
    role.can?(:manage_reports, :manage_users) && (record.public_visibility? || record.unlisted_visibility? || record.reported?)
  end

  def destroy?
    role.can?(:manage_reports)
  end

  def update?
    role.can?(:manage_reports)
  end

  def review?
    role.can?(:manage_taxonomies)
  end
end
