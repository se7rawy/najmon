# frozen_string_literal: true

class AnnouncementPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
