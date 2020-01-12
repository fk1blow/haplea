import { AddEntryMessageComponent } from './add-entry-message/add-entry-message.component';
import { CommonModule } from '@angular/common';
import { ConversationComponent } from './conversation.component';
import { ConversationService } from './conversation.service';
import { InputQueryMessageComponent } from './input-query-message/input-query-message.component';
import { MessageComponent } from './message/message.component';
import { NgModule } from '@angular/core';
import { ShowEntryMessageComponent } from './show-entry-message/show-entry-message.component';
import { SeeBeforeRelativeMessageComponent } from './see-before-relative-message/see-before-relative-message';
import { SeeYesterdatMessageComponent } from './see-yesterday-message/see-yesterday.component';

@NgModule({
  declarations: [
    ConversationComponent,
    MessageComponent,
    InputQueryMessageComponent,
    ShowEntryMessageComponent,
    AddEntryMessageComponent,
    SeeBeforeRelativeMessageComponent,
    SeeYesterdatMessageComponent
  ],
  imports: [
    CommonModule
  ],
  providers: [
    ConversationService
  ],
  exports: [
    ConversationComponent
  ],
  entryComponents: [
    AddEntryMessageComponent,
    ShowEntryMessageComponent,
    InputQueryMessageComponent,
    SeeBeforeRelativeMessageComponent,
    SeeYesterdatMessageComponent
  ]
})
export class ConversationModule { }
