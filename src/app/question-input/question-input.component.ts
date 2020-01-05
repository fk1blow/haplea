import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ConversationService } from '../conversation/conversation.service';

@Component({
  selector: 'hap-question-input',
  templateUrl: './question-input.component.html',
  styleUrls: ['./question-input.component.scss']
})
export class QuestionInputComponent implements OnInit {

  @ViewChild('questionInput', { static: true }) questionInput: ElementRef

  constructor(private conversationService: ConversationService) { }

  ngOnInit() {
  }

  onKeyDown(evt: KeyboardEvent) {
    if (evt.keyCode === 13) {
      const query = this.questionInput.nativeElement.value
      if (query.trim().length > 1) this.conversationService.push(query.trim())
      this.questionInput.nativeElement.value = ''
    }
  }

}
