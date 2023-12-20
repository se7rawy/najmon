# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

describe Mastodon::CLI::Maintenance do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#fix_duplicates' do
    let(:action) { :fix_duplicates }

    context 'when the database version is too old' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2000_01_01_000000) # Earlier than minimum
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('is too old')
          .and raise_error(SystemExit)
      end
    end

    context 'when the database version is too new and the user does not continue' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2100_01_01_000000) # Later than maximum
        allow(cli.shell).to receive(:yes?).with('Continue anyway? (Yes/No)').and_return(false).once
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('more recent')
          .and raise_error(SystemExit)
      end
    end

    context 'when Sidekiq is running' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2022_01_01_000000) # Higher than minimum, lower than maximum
        allow(Sidekiq::ProcessSet).to receive(:new).and_return [:process]
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('Sidekiq is running')
          .and raise_error(SystemExit)
      end
    end

    context 'when requirements are met' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2023_08_22_081029) # The latest migration before the cutoff
        agree_to_backup_warning
      end

      context 'with duplicate accounts' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_account_username) { 'username' }
        let(:duplicate_account_domain) { 'host.example' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating accounts',
              'Restoring index_accounts_on_username_and_domain_lower',
              'Reindexing textual indexes on accounts…',
              'Finished!'
            )
            .and change(duplicate_accounts, :count).from(2).to(1)
        end

        def duplicate_accounts
          Account.where(username: duplicate_account_username, domain: duplicate_account_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :accounts, name: :index_accounts_on_username_and_domain_lower
          Fabricate(:account, username: duplicate_account_username, domain: duplicate_account_domain)
          Fabricate.build(:account, username: duplicate_account_username, domain: duplicate_account_domain).save(validate: false)
        end
      end

      context 'with duplicate users on email' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_email) { 'duplicate@example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(email: duplicate_email)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :email
          Fabricate(:user, email: duplicate_email)
          Fabricate.build(:user, email: duplicate_email).save(validate: false)
        end
      end

      context 'with duplicate users on confirmation_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_confirmation_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting confirmation token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(confirmation_token: duplicate_confirmation_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :confirmation_token
          Fabricate(:user, confirmation_token: duplicate_confirmation_token)
          Fabricate.build(:user, confirmation_token: duplicate_confirmation_token).save(validate: false)
        end
      end

      context 'with duplicate users on reset_password_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_reset_password_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting password reset token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(reset_password_token: duplicate_reset_password_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :reset_password_token
          Fabricate(:user, reset_password_token: duplicate_reset_password_token)
          Fabricate.build(:user, reset_password_token: duplicate_reset_password_token).save(validate: false)
        end
      end

      context 'with duplicate account_domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_domain) { 'example.host' }
        let(:account) { Fabricate(:account) }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Removing duplicate account domain blocks',
              'Restoring account domain blocks indexes',
              'Finished!'
            )
            .and change(duplicate_account_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_account_domain_blocks
          AccountDomainBlock.where(account: account, domain: duplicate_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :account_domain_blocks, [:account_id, :domain]
          Fabricate(:account_domain_block, account: account, domain: duplicate_domain)
          Fabricate.build(:account_domain_block, account: account, domain: duplicate_domain).save(validate: false)
        end
      end

      context 'with duplicate announcement_reactions' do
        before do
          prepare_duplicate_data
        end

        let(:account) { Fabricate(:account) }
        let(:announcement) { Fabricate(:announcement) }
        let(:name) { Fabricate(:custom_emoji).shortcode }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Removing duplicate announcement reactions',
              'Restoring announcement_reactions indexes',
              'Finished!'
            )
            .and change(duplicate_announcement_reactions, :count).from(2).to(1)
        end

        def duplicate_announcement_reactions
          AnnouncementReaction.where(account: account, announcement: announcement, name: name)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :announcement_reactions, [:account_id, :announcement_id, :name]
          Fabricate(:announcement_reaction, account: account, announcement: announcement, name: name)
          Fabricate.build(:announcement_reaction, account: account, announcement: announcement, name: name).save(validate: false)
        end
      end

      context 'with duplicate conversations' do
        before do
          prepare_duplicate_data
        end

        let(:uri) { 'https://example.host/path' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating conversations',
              'Restoring conversations indexes',
              'Finished!'
            )
            .and change(duplicate_conversations, :count).from(2).to(1)
        end

        def duplicate_conversations
          Conversation.where(uri: uri)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :conversations, :uri
          Fabricate(:conversation, uri: uri)
          Fabricate.build(:conversation, uri: uri).save(validate: false)
        end
      end

      context 'with duplicate custom_emojis' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_shortcode) { 'wowzers' }
        let(:duplicate_domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating custom_emojis',
              'Restoring custom_emojis indexes',
              'Finished!'
            )
            .and change(duplicate_custom_emojis, :count).from(2).to(1)
        end

        def duplicate_custom_emojis
          CustomEmoji.where(shortcode: duplicate_shortcode, domain: duplicate_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :custom_emojis, [:shortcode, :domain]
          Fabricate(:custom_emoji, shortcode: duplicate_shortcode, domain: duplicate_domain)
          Fabricate.build(:custom_emoji, shortcode: duplicate_shortcode, domain: duplicate_domain).save(validate: false)
        end
      end

      context 'with duplicate custom_emoji_categories' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_name) { 'name_value' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating custom_emoji_categories',
              'Restoring custom_emoji_categories indexes',
              'Finished!'
            )
            .and change(duplicate_custom_emoji_categories, :count).from(2).to(1)
        end

        def duplicate_custom_emoji_categories
          CustomEmojiCategory.where(name: duplicate_name)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :custom_emoji_categories, :name
          Fabricate(:custom_emoji_category, name: duplicate_name)
          Fabricate.build(:custom_emoji_category, name: duplicate_name).save(validate: false)
        end
      end

      context 'with duplicate domain_allows' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating domain_allows',
              'Restoring domain_allows indexes',
              'Finished!'
            )
            .and change(duplicate_domain_allows, :count).from(2).to(1)
        end

        def duplicate_domain_allows
          DomainAllow.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :domain_allows, :domain
          Fabricate(:domain_allow, domain: domain)
          Fabricate.build(:domain_allow, domain: domain).save(validate: false)
        end
      end

      context 'with duplicate domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating domain_blocks',
              'Restoring domain_blocks indexes',
              'Finished!'
            )
            .and change(duplicate_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_domain_blocks
          DomainBlock.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :domain_blocks, :domain
          Fabricate(:domain_block, domain: domain)
          Fabricate.build(:domain_block, domain: domain).save(validate: false)
        end
      end

      context 'with duplicate email_domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating email_domain_blocks',
              'Restoring email_domain_blocks indexes',
              'Finished!'
            )
            .and change(duplicate_email_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_email_domain_blocks
          EmailDomainBlock.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :email_domain_blocks, :domain
          Fabricate(:email_domain_block, domain: domain)
          Fabricate.build(:email_domain_block, domain: domain).save(validate: false)
        end
      end

      def agree_to_backup_warning
        allow(cli.shell)
          .to receive(:yes?)
          .with('Continue? (Yes/No)')
          .and_return(true)
          .once
      end
    end
  end
end
