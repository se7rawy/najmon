import { FormattedMessage } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { fetchServer } from 'mastodon/actions/server';
import { domain } from 'mastodon/initial_state';

const mapStateToProps = state => ({
  message: state.getIn(['server', 'server', 'registrations', 'message']),
});

class ClosedRegistrationsModal extends ImmutablePureComponent {

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchServer());
  }

  render () {
    let closedRegistrationsMessage;

    if (this.props.message) {
      closedRegistrationsMessage = (
        <p
          className='prose'
          dangerouslySetInnerHTML={{ __html: this.props.message }}
        />
      );
    } else {
      closedRegistrationsMessage = (
        <p className='prose'>
          <FormattedMessage
            id='closed_registrations_modal.description'
            defaultMessage='Creating an account on {domain} is currently not possible, but please keep in mind that you do not need an account specifically on {domain} to use Mastodon.'
            values={{ domain: <strong>{domain}</strong> }}
          />
        </p>
      );
    }

    return (
      <div className='modal-root__modal interaction-modal'>
    

        <div className='interaction-modal__choices'>
          <div className='interaction-modal__choices__choice'>
           <h3>
            {closedRegistrationsMessage}  </h3>
             <a href='https://info.najmon.com' target='_blank'><FormattedMessage id='footer.info_center' defaultMessage='Info center' /></a>
          </div>
     
       
           
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps)(ClosedRegistrationsModal);
