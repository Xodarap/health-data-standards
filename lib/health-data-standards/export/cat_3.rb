module HealthDataStandards
  module Export
    class Cat3
      def initialize
        template_helper = HealthDataStandards::Export::TemplateHelper.new('cat3', 'cat3')
        @rendering_context = HealthDataStandards::Export::RenderingContext.new
        @rendering_context.template_helper = template_helper
        @cat1_renderer = HealthDataStandards::Export::RenderingContext.new
        @cat1_renderer.template_helper = HealthDataStandards::Export::TemplateHelper.new('cat1', 'cat1')
        @supplemental_info = get_supplemental_info
      end

      def get_supplemental_info
        vset = HealthDataStandards::SVS::ValueSet
        {:race => vset.where({:oid => '2.16.840.1.114222.4.11.836'}).first.concepts.map(&:code),
         :sex => ['F','M','UN'],  # 2.16.840.1.113883.1.11.1
         :ethnicity => vset.where({:oid => '2.16.840.1.114222.4.11.837'}).first.concepts.map(&:code),
         :payer => ['A', "B", 'C', 'D']
        }
      end

      def export(measures, header, effective_date, start_date, end_date, filter=nil,test_id=nil)
        results = {}
        measures.each do |measure|
          results[measure['hqmf_id']] = HealthDataStandards::CQM::QueryCache.aggregate_measure(measure['hqmf_id'], effective_date, filter, test_id)
        end
        @rendering_context.render(:template => 'show', 
                                  :locals => {:measures => measures, :start_date => start_date, 
                                              :end_date => end_date, :cat1_renderer => @cat1_renderer,
                                              :results => results, :supplemental_info => @supplemental_info,
                                              :header=>header})
      end
    end
  end
end