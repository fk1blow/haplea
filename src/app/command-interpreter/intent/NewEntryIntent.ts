import { isValid, parseISO, startOfToday } from 'date-fns';

import { IntentCommand } from '../IntentCommand';
import { WitEntities } from '../wit-interpreter.service';

export default class NewEntryIntent implements IntentCommand {

  private entryDate = startOfToday()

  get description() {
    return {
      path: 'expense/new', // not sure if this is an abstraction leak ok...
      created: this.entryDate
    }
  }

  constructor(entities: WitEntities) {
    const { datetime } = entities
    if (datetime && datetime[0]) {
      const datetimeParsed = parseISO(datetime[0].value)
      if (isValid(datetimeParsed)) this.entryDate = datetimeParsed
    }
  }

}