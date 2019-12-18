import { WitEntities } from './wit-interpreter.service';

export interface IntentCommandConstructor {
  new (n: WitEntities): IntentCommand;
}

export interface IntentCommand {
  description: { [key: string]: any }
}