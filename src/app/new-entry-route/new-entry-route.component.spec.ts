import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { NewEntryRouteComponent } from './new-entry-route.component';

describe('NewEntryRouteComponent', () => {
  let component: NewEntryRouteComponent;
  let fixture: ComponentFixture<NewEntryRouteComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ NewEntryRouteComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(NewEntryRouteComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
