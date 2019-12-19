import { Component, OnInit } from '@angular/core';
import { parseISO } from 'date-fns';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'hap-new-entry-route',
  templateUrl: './new-entry-route.component.html',
  styleUrls: ['./new-entry-route.component.scss']
})
export class NewEntryRouteComponent implements OnInit {

  get entryDate() {
    const date = this.route.snapshot.paramMap.get('date')
    return parseISO(date)
  }

  constructor(private route: ActivatedRoute) { }

  ngOnInit() { }

}
