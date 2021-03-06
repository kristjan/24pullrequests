class Gift < ActiveRecord::Base
  attr_accessible :user, :pull_request, :date

  class << self
    attr_writer :default_date
  end

  belongs_to :user
  belongs_to :pull_request

  validates :user, :presence => true
  validates :pull_request, :presence => true
  validates :date, :presence => true,
                   :uniqueness => { :scope => :user_id,
                                    :message => "you only need one gift per day. Save it for tomorrow!" },
                   :inclusion => { :in => Proc.new { Gift.giftable_dates },
                                   :message => "your gift should be for the month of December." }

  delegate :title, :issue_url, :to => :pull_request, :prefix => true

  def initialize(*args)
    result = super
    self.date = date || Gift.default_date

    result
  end

  def self.find(user_id, date)
    where(:user_id => user_id, :date => date).first
  end

  def self.giftable_dates
    1.upto(24).map { |day| Date.new(2012,12,day) }
  end

  def self.default_date
    @default_date ||= -> { Time.zone.now.to_date }
    @default_date.call
  end

  def to_param
    date.to_s
  end
end
