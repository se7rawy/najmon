import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { NavLink } from 'react-router-dom';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandPublicTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import { connectPublicStream } from '../../actions/streaming';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Federated timeline' },
});

const mapStateToProps = (state, { onlyMedia }) => ({
  hasUnread: state.getIn(['timelines', `public${onlyMedia ? ':media' : ''}`, 'unread']) > 0,
});

@connect(mapStateToProps)
@injectIntl
export default class PublicTimeline extends React.PureComponent {

  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    onlyMedia: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('PUBLIC', { other: { onlyMedia } }));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandPublicTimeline({ onlyMedia }));
    this.disconnect = dispatch(connectPublicStream({ onlyMedia }));
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia) {
      const { dispatch, onlyMedia } = this.props;

      this.disconnect();
      dispatch(expandPublicTimeline({ onlyMedia }));
      this.disconnect = dispatch(connectPublicStream({ onlyMedia }));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandPublicTimeline({ maxId, onlyMedia }));
  }

  handleHeadlineLinkClick = e => {
    e.preventDefault();

    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  render () {
    const { intl, columnId, hasUnread, multiColumn, onlyMedia } = this.props;
    const pinned = !!columnId;

    const headline = pinned ? (
      <div className='public-timeline__section-headline'>
        <a href='/timelines/public' className={!onlyMedia ? 'active' : undefined} onClick={this.handleHeadlineLinkClick}>
          <FormattedMessage id='timeline.posts' defaultMessage='Toots' />
        </a>
        <a href='/timelines/public/media' className={onlyMedia ? 'active' : undefined} onClick={this.handleHeadlineLinkClick}>
          <FormattedMessage id='timeline.media' defaultMessage='Media' />
        </a>
      </div>
    ) : (
      <div className='public-timeline__section-headline'>
        <NavLink exact to='/timelines/public' replace><FormattedMessage id='timeline.posts' defaultMessage='Toots' /></NavLink>
        <NavLink exact to='/timelines/public/media' replace><FormattedMessage id='timeline.media' defaultMessage='Media' /></NavLink>
      </div>
    );

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='globe'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          prepend={headline}
          timelineId={`public${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          trackScroll={!pinned}
          scrollKey={`public_timeline-${columnId}`}
          emptyMessage={<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other instances to fill it up' />}
        />
      </Column>
    );
  }

}
