import { IntentCommand } from '../IntentCommand';

export default class UndefinedIntent implements IntentCommand {

  get description() {
    return {
      path: 'undefined-intent'
    }
  }

}