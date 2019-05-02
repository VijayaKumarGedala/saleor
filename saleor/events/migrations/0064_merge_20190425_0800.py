# Generated by Django 2.2 on 2019-04-25 13:00

from django.db import migrations, models

from saleor.events import OrderEvents


def _move_updated_events_to_other(apps, *_args, **_kwargs):
    cls = apps.get_model('events', 'OrderEvent')

    for event in cls.objects.filter(type='updated').all():
        event.type = OrderEvents.OTHER
        event.parameters['message'] = (
            'Order details were updated by %(user_name)s' % {
                'user_name': event.user})
        event.save(update_fields=['type', 'parameters'])


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0063_auto_20180926_0446'),
        ('events', '0061_auto_20180920_0859'),
        ('events', '0054_move_data_to_order_events'),
        ('events', '0059_auto_20180913_0841'),
    ]

    operations = [
        migrations.AlterModelTable(
            name='orderevent',
            table=None,
        ),
        migrations.RunPython(_move_updated_events_to_other),
        migrations.AlterField(
            model_name='orderevent',
            name='type',
            field=models.CharField(choices=[('DRAFT_CREATED', 'draft_created'), ('DRAFT_ADDED_PRODUCTS', 'draft_added_products'), ('DRAFT_REMOVED_PRODUCTS', 'draft_removed_products'), ('PLACED', 'placed'), ('PLACED_FROM_DRAFT', 'draft_placed'), ('OVERSOLD_ITEMS', 'oversold_items'), ('CANCELED', 'canceled'), ('ORDER_MARKED_AS_PAID', 'marked_as_paid'), ('ORDER_FULLY_PAID', 'order_paid'), ('UPDATED', 'updated'), ('UPDATED_ADDRESS', 'updated_address'), ('EMAIL_SENT', 'email_sent'), ('PAYMENT_CAPTURED', 'captured'), ('PAYMENT_REFUNDED', 'refunded'), ('PAYMENT_VOIDED', 'voided'), ('PAYMENT_FAILED', 'payment_failed'), ('FULFILLMENT_CANCELED', 'fulfillment_canceled'), ('FULFILLMENT_RESTOCKED_ITEMS', 'restocked_items'), ('FULFILLMENT_FULFILLED_ITEMS', 'fulfilled_items'), ('TRACKING_UPDATED', 'tracking_updated'), ('NOTE_ADDED', 'note_added'), ('OTHER', 'other')], max_length=255),
        ),
    ]
