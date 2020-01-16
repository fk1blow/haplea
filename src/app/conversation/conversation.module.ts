import { AddEntryMessageComponent } from './add-entry-message/add-entry-message.component';
import { CommonModule } from '@angular/common';
import { ConversationComponent } from './conversation.component';
import { ConversationService } from './conversation.service';
import { InputQueryMessageComponent } from './input-query-message/input-query-message.component';
import { MessageComponent } from './message/message.component';
import { NgModule } from '@angular/core';
import { SeeBeforeRelativeMessageComponent } from './see-before-relative-message/see-before-relative-message';
import { SeeYesterdatMessageComponent } from './see-yesterday-message/see-yesterday.component';
import { FormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    ConversationComponent,
    MessageComponent,
    InputQueryMessageComponent,
    AddEntryMessageComponent,
    SeeBeforeRelativeMessageComponent,
    SeeYesterdatMessageComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
  ],
  providers: [
    ConversationService
  ],
  exports: [
    ConversationComponent
  ],
  entryComponents: [
    AddEntryMessageComponent,
    InputQueryMessageComponent,
    SeeBeforeRelativeMessageComponent,
    SeeYesterdatMessageComponent
  ]
})
export class ConversationModule { }
