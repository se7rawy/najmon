import React from 'react';
import PropTypes from 'prop-types';

const emptyComponent = () => null;
const noop = () => { };

class Bundle extends React.Component {

  static propTypes = {
    fetchComponent: PropTypes.func.isRequired,
    loading: PropTypes.func,
    error: PropTypes.func,
    children: PropTypes.func.isRequired,
    renderDelay: PropTypes.number,
    onRender: PropTypes.func,
    onFetch: PropTypes.func,
    onFetchSuccess: PropTypes.func,
    onFetchFail: PropTypes.func,
  }

  static defaultProps = {
    loading: emptyComponent,
    error: emptyComponent,
    renderDelay: 0,
    onRender: noop,
    onFetch: noop,
    onFetchSuccess: noop,
    onFetchFail: noop,
  }

  state = {
    mod: undefined,
    forceRender: false,
  }

  componentWillMount() {
    this.load(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.fetchComponent !== this.props.fetchComponent) {
      this.load(nextProps);
    }
  }

  componentDidUpdate () {
    this.props.onRender();
  }

  componentWillUnmount () {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  load = (props) => {
    const { fetchComponent, onFetch, onFetchSuccess, onFetchFail, renderDelay } = props || this.props;

    this.setState({ mod: undefined });
    onFetch();

    if (renderDelay !== 0) {
      this.timestamp = new Date();
      this.timeout = setTimeout(() => this.setState({ forceRender: true }), renderDelay);
    }

    return fetchComponent()
      .then((mod) => {
        this.setState({ mod: mod.default });
        onFetchSuccess();
      })
      .catch((error) => {
        this.setState({ mod: null });
        onFetchFail(error);
      });
  }

  render() {
    const { loading: Loading, error: Error, children, renderDelay } = this.props;
    const { mod, forceRender } = this.state;
    const elapsed = new Date() - this.timestamp;

    if (mod === undefined) {
      return (elapsed >= renderDelay || forceRender) ? <Loading /> : null;
    }

    if (mod === null) {
      return <Error onRetry={this.load} />;
    }

    return children(mod);
  }

}

export default Bundle;
