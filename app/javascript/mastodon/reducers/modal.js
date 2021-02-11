import { MODAL_OPEN, MODAL_CLOSE } from '../actions/modal';
import { TIMELINE_DELETE } from '../actions/timelines';

const initialState = {
  modalType: null,
  modalProps: {},
};

export default function modal(state = initialState, action) {
  switch(action.type) {
  case MODAL_OPEN:
    return { modalType: action.modalType, modalProps: action.modalProps };
  case MODAL_CLOSE:
    return (action.modalType === undefined || action.modalType === state.modalType) ? initialState : state;
  case TIMELINE_DELETE:
    if (state.modalProps.statusId === action.id) {
      return (action.modalType === undefined || action.modalType === state.modalType) ? initialState : state;
    } else {
      return state;
    }
  default:
    return state;
  }
};
