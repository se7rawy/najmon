import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { connect } from 'react-redux';

import { openModal } from 'mastodon/actions/modal';
import { domain, version, source_url, statusPageUrl, profile_directory as profileDirectory } from 'mastodon/initial_state';
import { PERMISSION_INVITE_USERS } from 'mastodon/permissions';
import { logOut } from 'mastodon/utils/log_out';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapDispatchToProps = (dispatch, { intl }) => ({
  onLogout () {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.logoutMessage),
        confirm: intl.formatMessage(messages.logoutConfirm),
        closeWhenConfirm: false,
        onConfirm: () => logOut(),
      },
    }));
  },
});

class LinkFooter extends PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    multiColumn: PropTypes.bool,
    onLogout: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleLogoutClick = e => {
    e.preventDefault();
    e.stopPropagation();

    this.props.onLogout();

    return false;
  };

  render () {
    const { signedIn, permissions } = this.context.identity;
    const { multiColumn } = this.props;

    const canInvite = signedIn && ((permissions & PERMISSION_INVITE_USERS) === PERMISSION_INVITE_USERS);
    const canProfileDirectory = profileDirectory;

    const DividingCircle = <span aria-hidden>{' · '}</span>;

    return (
      <div className='link-footer'>
        <p>
   
          {' '}
          <Link to='/about' target={multiColumn ? '_blank' : undefined}><FormattedMessage id='footer.about' defaultMessage='About' /></Link>
          {statusPageUrl && (
            <>
              {DividingCircle}
              <a href={statusPageUrl} target='_blank' rel='noopener'><FormattedMessage id='footer.status' defaultMessage='Status' /></a>
            </>
          )}
          {canInvite && (
            <>
              {DividingCircle}
              <a href='/invites' target='_blank'><FormattedMessage id='footer.invite' defaultMessage='Invite people' /></a>
            </>
          )}
     
          {DividingCircle}
          <Link to='/privacy-policy' target={multiColumn ? '_blank' : undefined}><FormattedMessage id='footer.privacy_policy' defaultMessage='Privacy policy' /></Link>
        {DividingCircle}
          <Link to='/keyboard-shortcuts'><FormattedMessage id='footer.keyboard_shortcuts' defaultMessage='Keyboard shortcuts' /></Link>
  </p>

   
      </div>
    );
  }

}

export default injectIntl(connect(null, mapDispatchToProps)(LinkFooter));
