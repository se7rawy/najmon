# frozen_string_literal: true

require 'rails_helper'

describe Import::RowWorker do
  subject { described_class.new }

  let(:row) { Fabricate(:bulk_import_row, bulk_import: import) }

  describe '#perform' do
    before do
      allow(BulkImportRowService).to receive(:new).and_return(service_double)
    end

    shared_examples 'clean failure' do
      let(:service_double) { instance_double(BulkImportRowService, call: false) }

      it 'calls BulkImportRowService, increases processed items, preserves imported items, preserves the row' do
        expect { subject.perform(row.id) }
          .to increase_processed_items
          .and(preserve_imported_items)

        expect(service_double).to have_received(:call).with(row)
        expect(BulkImportRow.exists?(row.id)).to be true
      end
    end

    shared_examples 'unclean failure' do
      let(:service_double) { instance_double(BulkImportRowService) }

      before do
        allow(service_double).to receive(:call) do
          raise 'dummy error'
        end
      end

      it 'raises an error and does not change processed items count or delete the row' do
        expect { subject.perform(row.id) }
          .to raise_error(StandardError, 'dummy error')
          .and(not_change { import.reload.processed_items })
          .and(not_change { BulkImportRow.exists?(row.id) })
      end
    end

    shared_examples 'clean success' do
      let(:service_double) { instance_double(BulkImportRowService, call: true) }

      it 'calls BulkImportRowService, increases processed items, increased imported items, deletes row' do
        expect { subject.perform(row.id) }
          .to increase_processed_items
          .and(increase_imported_items)
          .and(delete_the_row)

        expect(service_double).to have_received(:call).with(row)
      end
    end

    def increase_processed_items
      change { import.reload.processed_items }.by(1)
    end

    def increase_imported_items
      change { import.reload.imported_items }.by(1)
    end

    def preserve_imported_items
      not_change { import.reload.imported_items }
    end

    def delete_the_row
      change { BulkImportRow.exists?(row.id) }.from(true).to(false)
    end

    context 'when there are multiple rows to process' do
      let(:import) { Fabricate(:bulk_import, total_items: 2, processed_items: 0, imported_items: 0, state: :in_progress) }

      context 'with a clean failure' do
        include_examples 'clean failure'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }.to_not(change { import.reload.state.to_sym })
        end
      end

      context 'with an unclean failure' do
        include_examples 'unclean failure'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }.to raise_error(StandardError).and(not_change { import.reload.state.to_sym })
        end
      end

      context 'with a clean success' do
        include_examples 'clean success'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }.to_not(change { import.reload.state.to_sym })
        end
      end
    end

    context 'when this is the last row to process' do
      let(:import) { Fabricate(:bulk_import, total_items: 2, processed_items: 1, imported_items: 0, state: :in_progress) }

      context 'with a clean failure' do
        include_examples 'clean failure'

        it 'marks the import as finished' do
          expect { subject.perform(row.id) }.to change { import.reload.state.to_sym }.from(:in_progress).to(:finished)
        end
      end

      # NOTE: sidekiq retry logic may be a bit too difficult to test, so leaving this blind spot for now
      it_behaves_like 'unclean failure'

      context 'with a clean success' do
        include_examples 'clean success'

        it 'marks the import as finished' do
          expect { subject.perform(row.id) }.to change { import.reload.state.to_sym }.from(:in_progress).to(:finished)
        end
      end
    end
  end
end
