require 'spec_helper'

describe Shoryuken::Fetcher do
  let(:manager)   { double Shoryuken::Manager }
  let(:sqs_queue) { double 'sqs_queue' }
  let(:queue)     { 'shoryuken' }
  let(:sqs_msg)   { double 'SQS msg'}

  subject { described_class.new(manager) }

  before do
    allow(manager).to receive(:async).and_return(manager)
    allow(Shoryuken::Client).to receive(:queues).with(queue).and_return(sqs_queue)
  end

  describe '#fetch' do
    it 'calls pause_queue! when not found' do
      allow(sqs_queue).to receive(:receive_message).with(limit: 1).and_return([])

      expect(manager).to receive(:pause_queue!).with(queue)
      expect(manager).to receive(:dispatch)

      subject.fetch(queue, 1)
    end

    it 'assigns messages' do
      allow(sqs_queue).to receive(:receive_message).with(limit: 5).and_return(sqs_msg)

      expect(manager).to receive(:rebalance_queue_weight!).with(queue)
      expect(manager).to receive(:assign).with(queue, sqs_msg)
      expect(manager).to receive(:dispatch)

      subject.fetch(queue, 5)
    end
  end
end
