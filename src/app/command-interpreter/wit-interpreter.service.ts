import { Injectable } from '@angular/core';
import { IntentCommand } from './IntentCommand';
import NewEntryIntent from './intent/NewEntryIntent';
import UndefinedIntent from './intent/UndefinedIntent';

export interface WitIntent {
  confidence: number
  value: string
}

export interface WitDatetime {
  confidence: number
  grain: 'day'
  value: string // datetime string
}

export interface WitEntities {
  intent?: WitIntent[]
  datetime?: WitDatetime[]
}

@Injectable({
  providedIn: 'root'
})
export class WitInterpreterService {

  constructor() { }

  interpret(entities: WitEntities): IntentCommand {
    console.log('entities: ', entities);


    if (!entities.intent || entities.intent.length < 1) {
      return new UndefinedIntent()
    }
    return this.buildIntent(entities)
  }

  private buildIntent(entities: WitEntities) {
    let intentTemplate = null
    const intentType = entities.intent[0]

    switch (intentType.value) {
      case 'new-entry':
        intentTemplate = new NewEntryIntent(entities)
      break;

      default:
        intentTemplate = null;
    }

    return intentTemplate
  }

}
